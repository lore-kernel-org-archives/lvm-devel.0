From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 17 Feb 2011 10:19:57 +0100
Subject: Announcing "Cluster in a BOX" project
Message-ID: <4D5CE83D.7050400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA256

Hi all,

A lot of people find it hard to setup their first cluster or simply
don?t have time to repeat the same setup over and over, either for
development or do some basic testing or to showcase cluster technologies
to other people.

The  "Cluster in a BOX" project (cbox in short), is one script to setup
a KVM based virtual test cluster in a matter of few minutes.

cbox is still in its early development, has several limitations and some
strict requirements.

Plans are to include as many cluster technologies and configuration
examples as possible and remove as many limitations as we possibly can.

If your cluster project or technology is not there yet, or your
distribution is not supported, it?s simply because I do not have the
resources to do all by myself. Do not take it personally, we will get it
there together and I absolutely welcome comments, patches and feedback
at any time.

Support for pacemaker, DRBD and OCFS2 will come shortly.

cbox documentation is here (in temporary lack of a more neutral location):

http://sources.redhat.com/cluster/wiki/cluster_in_a_box

Please read it carefully before running cbox.

Fabio
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (MingW32)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCAAGBQJNXOg6AAoJEFA6oBJjVJ+Oky4QAIYZptGXaEeCuOIUhyalZrxA
Piuc05L5De6Nsfe7EtVQmut+mylK2uuF8DmErenIsmy/uIlX7xPHx5vzeOxE0nWk
xTvEjVnAL4t36CNf8AfrVXJ7F+4OsRqNrXjukxTJ7lbq72aYqtr8NQDL7sEfCSBp
XQSywRWIdxjqC5JGHNtKN/rSdcD6AlMt9EutvDHJkWZtzLFAZhbxdPkj0sTDyAWp
qje2Bnsz/BfNLcfnxEhGZsZ+ZH1X/A3ps6xT5EIPo3r3l52HTOSCXNLYLBIY4+pK
E4IdzRLwJOQqYujPjYsMeESBww2cgDFSJFHW/AR5YZCE7MkjS/e/BkZxXBkZY5dq
YFR9KTU1GvQi8Hwi32pDYJXcd0bbkKT/Cq73a2/bkwEqwBR2oWisr/lI196SGKaW
PVBNUM2N4DPxv6Rc3tg966ZycAkR/PM8oa1EbojAC9hl7eM5yQADAzs9mof/YISt
1Nay4gdDYEEzH5Mt6pozUZaK6sQcz63C/vrxGsQZAjAXwZz87jmlHOoLBWGhVj6a
Z/FEWo0ofaYBBQKQnboz4V9EKFP3M4yhJ8vDcWUa3qwaDL9X2BVCg/dtuLq3Q51O
szFMibYzw73Xr4K2CS/XlVZQ4Lykfy7gEKxeEIo/7287W2keL/YgXtuVf+17ZUkl
bdhqV0OXF8hq/xMC+OeU
=QTI7
-----END PGP SIGNATURE-----


