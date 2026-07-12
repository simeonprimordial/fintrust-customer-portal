# from flask import Blueprint, render_template, request, redirect, url_for

# from .extensions import db
# from .models import Customer

# main = Blueprint("main", __name__)


# @main.route("/")
# def home():
#     return render_template("index.html")


# @main.route("/health")
# def health():
#     return {"status": "healthy"}, 200


# @main.route("/customers")
# def customers():

#     customers = Customer.query.order_by(Customer.id).all()

#     return render_template(
#         "customers.html",
#         customers=customers
#     )


# @main.route("/customers/add", methods=["GET", "POST"])
# def add_customer():

#     if request.method == "POST":

#         customer = Customer(

#             name=request.form["name"],

#             email=request.form["email"],

#             balance=request.form["balance"]

#         )

#         db.session.add(customer)

#         db.session.commit()

#         return redirect(url_for("main.customers"))

#     return render_template("add_customer.html")



from flask import Blueprint, render_template, request, redirect, url_for

main = Blueprint("main", __name__)

# Temporary mock database
customers = [
    {
        "id": 1,
        "name": "John Doe",
        "email": "john@example.com",
        "balance": 2500.00
    },
    {
        "id": 2,
        "name": "Jane Smith",
        "email": "jane@example.com",
        "balance": 4200.00
    }
]


@main.route("/")
def home():
    return render_template("index.html")


@main.route("/health")
def health():
    return {"status": "healthy"}, 200


@main.route("/customers")
def customer_list():
    return render_template(
        "customers.html",
        customers=customers
    )


@main.route("/customers/add", methods=["GET", "POST"])
def add_customer():

    if request.method == "POST":

        new_customer = {
            "id": len(customers) + 1,
            "name": request.form["name"],
            "email": request.form["email"],
            "balance": float(request.form["balance"])
        }

        customers.append(new_customer)

        return redirect(url_for("main.customer_list"))

    return render_template("add_customer.html")

@main.route("/customers/edit/<int:id>", methods=["GET", "POST"])
def edit_customer(id):

    customer = next(
        (c for c in customers if c["id"] == id),
        None
    )

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

    customer = next(
        (c for c in customers if c["id"] == id),
        None
    )

    if customer:
        customers.remove(customer)

    return redirect(
        url_for("main.customer_list")
    )