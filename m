From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 08 Oct 2009 16:14:34 -0500
Subject: [PATCH 0 of 10] LVM: Mirrored log support
Message-ID: <1255036474.12319.16.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I spent the last few days looking over the mirror allocation code.  I
wanted to understand why 'log_count' was being treated generically in
most places... as if the idea of mirrored logs were already thought of.
I mostly discovered that it was possible to push what looked like
incomplete code towards completion.  The following patches represent
where I would like the mirrored log support to start from.

These patches are a replacement to the proposed patches - a fresh start.
They address a couple problems that I saw with the old patches: 1)
Allocation policies are respected and behave the same as today for other
log types.
2) The on-disk layout of the previous version - when given only two
disks to allocate from - would put the log on the front of one device
and the back of another.  This virtually ensures a performance hit.
These patches put the logs in the same place WRT the images.
3) The new patches reduce parameter bloat.  I think the previous patches
required the extra parameters because they were using functions deep in
the code that were from higher levels... adding parameters and
"spaghettifying" the code.

These patches should be considered a starting point.  While 'lvcreate'
works, 'lvconvert' does not handle all transitions.  In fact,
'lvconvert' will only handle 'core' -> 'disk/redundant' and
'disk/redundant' -> 'core'.  It will not handle 'disk' <-> 'redundant'.

 brassow


