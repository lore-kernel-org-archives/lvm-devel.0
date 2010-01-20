From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 Jan 2010 18:16:49 +0100
Subject: [PATCH] dmeventd plugins v. LVM mutexing
Message-ID: <87wrzc1yta.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch should address RHBZ 557104, in the following way:

- a common library for lvm-based dmeventd plugins is added that proxies
  the access to lvm library
- this supersedes the per-plugin mutexing we have been using and which
  breaks as soon as multiple plugins try to use lvm simultaneously

It should not affect backwards compatibility and the change is confined
to dmeventd plugins only.

Not very well tested yet (just basic check that things link and load).

The patch applies on top of the debug patch I have sent previously and
undoes part of it (but it keeps the basic (non-debug) logging, and also
extends it to the snapshot monitoring plugin).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd.diff
Type: text/x-diff
Size: 19720 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100120/13772d6b/attachment.bin>
