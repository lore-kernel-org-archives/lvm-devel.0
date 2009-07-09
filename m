From: Petr Rockai <prockai@redhat.com>
Date: Thu, 09 Jul 2009 21:50:12 +0200
Subject: [PATCH] unknown segment types, part 1
In-Reply-To: <4A562E89.5020601@redhat.com> (Milan Broz's message of "Thu, 09
	Jul 2009 19:53:13 +0200")
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
	<4A56288F.4080604@redhat.com> <4A562E89.5020601@redhat.com>
Message-ID: <87ocrt8wln.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Milan Broz <mbroz@redhat.com> writes:
> Actually only comments and some fancy formatting is lost. Is that correct?

Yes. We lose those because they are not parsed at all, so we cannot quite
reproduce them. Editing the metadata with LVM that understands the segment type
will restore the fancy comments and formatting (since these are hard-coded in
the export code for any given segment).

See also the testcase: doing a restore/backup cycle will restore the
(formatting-lost) volume group to exactly the same state as before.

Yours,
   Petr.


