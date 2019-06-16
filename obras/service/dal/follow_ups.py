from flask_restplus import fields

from genl.restplus import api
from misc.helperpg import EmptySetError

from .entity import count_entities, delete_entity, find_entity
from .helper import exec_steady, run_store_procedure

model = api.model(
    "Follow Up Model",
    {
        "id": fields.Integer(description="The unique db identifier"),
        "project": fields.Integer(required=True, description="Id of project"),
        "verified_progress": fields.Integer(),
        "financial_advance": fields.Integer(),
        "img_paths": fields.String(),
        "check_stage": fields.Integer(),
        "check_date": fields.Date(),
        "inceptor_uuid": fields.String(required=True, description="UUID of creator"),
    },
)


def _setup_search_criteria(search_params):
    criteria = []
    for field, value in search_params.items():
        criteria.append(f"follow_ups.{field} = {value}")

    return " AND ".join(criteria)


def _alter_follow_ups(**kwargs):
    """Calls a store procedure to create or edit a follow up record"""
    sql = """SELECT * FROM alter_follow_ups(
    {}::integer,
    {}::integer,
    {}::smallint,
    {}::smallint,
    '{}'::text,
    {}::integer,
    '{}'::date,
    '{}'::character varying
    )
    AS result(rc integer, msg text)""".format(
        kwargs["id"],
        kwargs["project"],
        kwargs["verified_progress"],
        kwargs["financial_advance"],
        kwargs["img_paths"],
        kwargs["check_stage"],
        kwargs["check_date"],
        kwargs["inceptor_uuid"],
    )

    return run_store_procedure(sql)


def create(**kwargs):
    """Creates follow up entity"""
    kwargs["id"] = 0
    return _alter_follow_ups(**kwargs)


def edit(**kwargs):
    return _alter_follow_ups(**kwargs)


def block(follow_up_id):
    """Logical deletion of a follow up"""
    delete_entity("follow_ups", follow_up_id)


def find(follow_up_id):
    return find_entity("follow_ups", follow_up_id)


def count(search_params=None):
    """Returns the number of non-logically deleted follow-ups"""
    return count_entities("follow_ups", search_params)


def paged(offset, limit, order_by, order, search_params=None):
    query = """SELECT *
           FROM follow_ups
           WHERE blocked = false"""

    if search_params is not None:
        query += " AND " + _setup_search_criteria(search_params)

    query += f" ORDER BY {order_by} {order} LIMIT {limit} OFFSET {offset}"

    try:
        rows = exec_steady(query)
    except EmptySetError:
        return []

    entities = []
    for row in rows:
        entities.append(dict(row))

    return entities