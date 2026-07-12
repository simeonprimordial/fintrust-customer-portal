from flask import Blueprint, render_template, request, redirect, url_for

from .extensions import db
from .models import Customer

main = Blueprint("main", __name__)

@main.route("/")
def home():
    return render_template("index.html")


@main.route("/health")
def health():
    return {"status": "healthy"}, 200


@main.route("/customers")
def customer_list():
    customers = Customer.query.order_by(Customer.id).all()

    return render_template(
            "customers.html",
            customers=customers
)


@main.route("/customers/add", methods=["GET", "POST"])
def add_customer():

    if request.method == "POST":

        new_customer = Customer(
            name=request.form["name"],
            email=request.form["email"],
            balance=float(request.form["balance"])
        )
        db.session.add(new_customer)
        db.session.commit()


    return render_template("add_customer.html")

@main.route("/customers/edit/<int:id>", methods=["GET", "POST"])
def edit_customer(id):

    customer = Customer.query.get_or_404(id)

    if customer is None:
        return "Customer not found", 404

    if request.method == "POST":

        customer["name"] = request.form["name"]
        customer["email"] = request.form["email"]
        customer["balance"] = float(
            request.form["balance"]
        )

        return redirect(
            url_for("main.customer_list")
        )

    return render_template(
        "edit_customer.html",
        customer=customer
    )

@main.route("/customers/delete/<int:id>")
def delete_customer(id):

    customer = Customer.query.get_or_404(id)

    db.session.delete(customer)

    db.session.commit()

    return redirect(
        url_for("main.customer_list")
    )