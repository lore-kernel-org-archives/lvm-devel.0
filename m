From: Bryn M. Reeves <bmr@redhat.com>
Date: Fri, 20 Mar 2009 16:10:07 +0000
Subject: lvcreate -s - why specifying size for snapshot ?
In-Reply-To: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
References: <37d33d830903200847w45cee0b1xc973299627dead2f@mail.gmail.com>
Message-ID: <49C3BFDF.1090900@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Sandeep K Sinha wrote:
> Hi all,
> Disk
> After hunting for relevant documents and failing to find one.
> I would like to know if its not true that the size of the snapshot
> should be equal to the original volume?
> If so, then why do we accept size for a snapshot?
> 
> Or Am I missing something somewhere else?
> 

The size of the snapshot governs the amount of space set aside for
storing the changes to the origin volume. E.g. if you made a snapshot
and then completely overwrote the origin the snapshot would have to be
at least as big as the origin volume to hold the changes.

You need to dimension a snapshot according to the expected level of
change. So for example a short-lived snapshot of a read-mostly volume,
e.g. /usr, would need less space than a long-lived snapshot of a volume
that sees a greater number of writes such as /home.

Snapshots can be grown after they have been created but you need to make
sure they don't fill up. If this happens the snapshot will become
invalid (since it can no longer faithfully track changes on the origin
volume).

Regards,
Bryn.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Using GnuPG with Fedora - http://enigmail.mozdev.org

iEYEARECAAYFAknDv98ACgkQ6YSQoMYUY95s2wCfQwnpoTiHL+8xhuifVX4YGoJz
TW0Ani+qq0uDmwgAKbHAVUiwEO6MLGtN
=D2F3
-----END PGP SIGNATURE-----


