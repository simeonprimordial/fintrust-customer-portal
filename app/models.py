from .extensions import db


class Customer(db.Model):
    __tablename__ = "customers"

    id = db.Column(db.Integer, primary_key=True)

    name = db.Column(db.String(100), nullable=False)

    email = db.Column(db.String(120), unique=True, nullable=False)

    balance = db.Column(db.Float, nullable=False)

    def __repr__(self):
        return f"<Customer {self.name}>"