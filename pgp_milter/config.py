# -*- coding: utf-8 -*-
import pathlib
from configparser import ConfigParser


OPTIONS_DEFAULTS = dict(
    socket="inet6:12345@localhost",
    debug=False,
)


def config_paths():
    """Paths, where we look for config files.
    """
    return [
        pathlib.Path("/etc/pgpmilter.cfg").absolute(),
        pathlib.Path(pathlib.Path.home(), ".pgpmilter.cfg").absolute(),
        pathlib.Path("pgpmilter.cfg").absolute(),
        ]


def get_config_dict():
    result = dict(OPTIONS_DEFAULTS)
    parser = ConfigParser()
    parser.read_dict({"pgpmilter": OPTIONS_DEFAULTS})
    found = parser.read(config_paths())
    for key, val in OPTIONS_DEFAULTS.items():
        if not parser.has_option("pgpmilter", key):
            continue
        if isinstance(val, bool):
            result[key] = parser.getboolean("pgpmilter", key)
        elif isinstance(val, int):
            result[key] = parser.getint("pgpmilter", key)
        else:
            result[key] = parser.get("pgpmilter", key).strip("\"'")
    return result
