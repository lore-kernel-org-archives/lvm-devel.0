From: Stas Sergeev <stsp@aknet.ru>
Date: Mon, 08 Dec 2008 11:26:01 +0300
Subject: broken vg after vgconvert -M1, trying to recover
In-Reply-To: <20081205125711.GA26097@agk.fab.redhat.com>
References: <49391424.8090505@aknet.ru>
	<20081205125711.GA26097@agk.fab.redhat.com>
Message-ID: <493CDA19.805@aknet.ru>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello.

Alasdair G Kergon wrote:
> To recover, you should: update to a newer version such as 2.02.42 or 2.02.43,
> find a suitable metadata backup file, edit it to ensure the LV UUIDs are
> compatible with LVM1 (ie small consecutive numbers with leading zeroes)
> then use vgcfgrestore.
OK, I recovered the backup from the
partition dump and upgraded lvm2 to
2.0.43. I changed the LV IDs, and
vgcfgrestore says this:
---
  PV /dev/sdb3 is a different format (seqno lvm1)
  Restore failed.
---

And if I also change the pv0 id,
I get this:
---
  Couldn't find device with uuid '000000-0000-0000-0000-0000-0000-000009'.
Segmentation fault
---

The segfault comes from archiver.c:296 -
pv->dev is NULL here, but the check is
missing.
Attached is my restored metadata backup.
Please let me know how can I recover from
that.

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: bb
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081208/c0172d49/attachment.ksh>
