import os

from sqlalchemy.engine import URL


class Config:
    """Application configuration loaded exclusively from the environment."""

    # Fail fast instead of silently starting with a public development secret.
    SECRET_KEY = os.environ["SECRET_KEY"]

    DB_USERNAME = os.environ["DB_USERNAME"]
    DB_PASSWORD = os.environ["DB_PASSWORD"]
    DB_HOST = os.environ["DB_HOST"]
    DB_PORT = int(os.getenv("DB_PORT", "3306"))
    DB_NAME = os.environ["DB_NAME"]

    # URL.create safely escapes generated passwords containing reserved URL
    # characters such as @, :, /, or #.
    SQLALCHEMY_DATABASE_URI = URL.create(
        drivername="mysql+pymysql",
        username=DB_USERNAME,
        password=DB_PASSWORD,
        host=DB_HOST,
        port=DB_PORT,
        database=DB_NAME,
    )

    SQLALCHEMY_TRACK_MODIFICATIONS = False
    SQLALCHEMY_ENGINE_OPTIONS = {
        "pool_pre_ping": True,
        "pool_recycle": 280,
    }
