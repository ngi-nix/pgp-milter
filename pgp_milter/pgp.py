# -*- coding: utf-8 -*-
#
# OpenPGP related stuff
#
import email.mime.text
from email.mime.application import MIMEApplication
from email.mime.multipart import MIMEMultipart
from email.parser import Parser
from email.policy import default as default_policy


def parse_raw(headers, body):
    """Turn headers and body of an email into message
    object.
    """
    str_headers = b"\n".join([b"%s: %s" % (k, v) for k, v in headers])
    raw_msg = "%s\n\n\n%s" % (str_headers.decode(), body.decode())
    return Parser(policy=default_policy).parsestr(raw_msg)


def gpg_encrypt(gpg_env, text, fpr):
    """Encrypt `text` for fingerprint `fpr`.
    """
    return gpg_env.encrypt(text, fpr, always_trust=True)


def pgp_mime_encrypt(gpg_env, mime_msg, fpr):
    """Create PGP encrypted message from ordinary MIME message

    The returned multipart MIME container should conform to RFC 3156.
    """
    to_encrypt = get_encryptable_payload(mime_msg)
    enc_msg = gpg_encrypt(gpg_env, to_encrypt.as_string(), fpr)
    multipart_container = MIMEMultipart(
        "encrypted", protocol="application/pgp-encrypted"
    )
    part1 = MIMEApplication(
        _data="Version: 1\n",
        _subtype="pgp-encrypted",
        _encoder=email.encoders.encode_7or8bit,
    )
    multipart_container.attach(part1)
    part2 = MIMEApplication(
        _data=str(enc_msg),
        _subtype="octet-stream; name=encrypted.asc",
        _encoder=email.encoders.encode_7or8bit,
    )
    multipart_container.attach(part2)
    multipart_container["Content-Disposition"] = "inline"
    return multipart_container


def as_mime(text):
    return email.mime.text.MIMEText(_text=text)


def get_encryptable_payload(msg):
    """Get the 'inner' content of a message.

    I.e. the part that should be encrypted when outward bound. Expects and
    returns an `email.message.EmailMessage` object.
    """
    for k in msg.keys():  # remove headers not "encrypted".
        if k.startswith("Content-"):
            continue
        del msg[k]
    return msg
