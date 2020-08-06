import pgp_milter
import pytest
import Milter.testctx
from Milter.test import TestBase as MilterTestBase
from pgp_milter import (
    __version__,
    handle_options,
    main,
    PGPMilter,
)
try:
    import importlib.metadata as importlib_metadata
except ImportError:  # Python < 3.8 # NOQA  # pragma: no cover
    import importlib_metadata


class PGPTestMilter(MilterTestBase, PGPMilter):
    """A test milter wrapping PGPMilter
    """
    def __init__(self):
        MilterTestBase.__init__(self, logfile="milter.log")


def test_importable():
    # we can import pgp_milter
    assert pgp_milter is not None


def test_version():
    # assure versions in setup.py and package match
    v1 = __version__
    v2 = importlib_metadata.version("pgp_milter")
    assert v1 == v2


def test_handle_options_defaults():
    # we can expect sensible defaults set
    args = handle_options([])
    assert args.version is False
    assert args.debug is False
    assert args.socket == "inet6:30072@[::1]"


def test_handle_options_debug():
    # we can enable debug mode
    assert handle_options([]).debug is False
    assert handle_options(["-d"]).debug is True
    assert handle_options(["--debug"]).debug is True


def test_handle_options_socket():
    # we can set a connection socket to bind to
    assert handle_options([]).socket == "inet6:30072@[::1]"
    assert handle_options(
        ["-s=inet:6666@1.1.1.1"]).socket == "inet:6666@1.1.1.1"
    assert handle_options(
        ["--socket=inet:6666@1.1.1.1"]).socket == "inet:6666@1.1.1.1"


def test_handle_options_version():
    # we support `--version'
    assert handle_options(["--version"]).version is True
    assert handle_options([]).version is False


def test_main_version(capsys):
    # we can output the version
    with pytest.raises(SystemExit):
        main(["--version"])
    out, err = capsys.readouterr()
    assert str(__version__) in out


def test_main_sys_argv_considered(capsys, monkeypatch):
    # we consider args set in sys.argv if none are passed in
    monkeypatch.setattr("sys.argv", ["scriptname", "--version"])
    with pytest.raises(SystemExit):
        main()
    out, err = capsys.readouterr()
    assert str(__version__) in out


def test_pgp_milter_constructable():
    # we can create PGPMilters
    m = PGPMilter()
    assert hasattr(m, "_id")
    assert isinstance(m, PGPMilter)


class TestPGPMilter(object):
    def test_create(self):
        # we can create PGPMilters
        assert PGPMilter() is not None

    def test_connect(self):
        # we handle connects properly
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        rc = ctx._connect("sample.host")
        assert rc == Milter.NOREPLY
        assert ctx.getpriv()._ip_name == "sample.host"

    def test_header(self):
        # header lines are stored
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        ctx._connect()
        ctx._header("X-Foo", "foo")
        ctx._header("X-Foo", "bar")
        m = ctx.getpriv()
        assert m.headers_seen == [("X-Foo", "foo"), ("X-Foo", "bar")]

    def test_envfrom_blanks_seen_data(self):
        # stored messages and headers are blanked on each msg from
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        ctx._connect()
        ctx._envfrom("foo@bar")
        ctx._header("X-Foo", "foo")
        assert ctx.getpriv().fp is not None
        assert b"X-Foo" in ctx.getpriv().fp.getvalue()
        ctx._envfrom("bar@baz")
        assert b"X-Foo" not in ctx.getpriv().fp.getvalue()

    def test_envrcpt_stores_recipients(self):
        # we store all recipients sent by RCPT TO
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        ctx._connect()
        ctx._envfrom("<foo@bar>")
        rc1 = ctx._envrcpt("<bar@bar>")
        rc2 = ctx._envrcpt("<baz@bar>")
        assert rc1 == rc2 == Milter.CONTINUE
        assert ctx.getpriv().rcpts == ["<bar@bar>", "<baz@bar>"]

    def test_envrcpt_list_empty_on_beginning(self):
        # at the beginning the recipients list is empty
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        ctx._connect()
        assert ctx.getpriv().rcpts == []

    def test_envrcpt_reset_on_mailfrom(self):
        # on MAIL FROM, any recipients are removed
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        ctx._connect()
        ctx._envfrom("<foo@bar>")
        ctx._envrcpt("<bar@bar>")
        assert ctx.getpriv().rcpts == ["<bar@bar>"]
        ctx._envfrom("<foo@bar>")
        assert ctx.getpriv().rcpts == []

    def test_x_pgpmilter_header_added(self):
        # the X-PGPMilter header is added during eom()
        milter = PGPTestMilter()
        assert milter.connect() == Milter.CONTINUE
        with open("tests/samples/full-mail01", "rb") as fp:
            rc = milter.feedFile(fp)
            assert rc == Milter.ACCEPT
        assert "X-PGPMilter" in milter._msg.keys()

    def test_close_closes_also_fp(self):
        # the local filepointer is closed then the connection closes.
        ctx = Milter.testctx.TestCtx()
        Milter.factory = PGPMilter
        ctx._connect()
        ctx._envfrom("foo@bar")
        ctx._header("X-Foo", "foo")
        assert ctx.getpriv().fp.closed is False
        ctx._close()
        assert ctx.getpriv().fp.closed is True


# vim: expandtab ts=4 sw=4
