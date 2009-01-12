From: Petr Rockai <prockai@redhat.com>
Date: Mon, 12 Jan 2009 15:07:55 +0100
Subject: [PATCH] New library interface for vg_read.
Message-ID: <1231769286-15534-1-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Hi,

this is a once-more rehashed set of patches. I have re-done the changes in a
different, more structured order. The patches towards the end (not touching
library) should be fairly independent of each other -- these can be applied
without applying the rest. The patches toward the start of the sequence are
adding library bits that will be used by the later patches. Generally, the
library patches shouldn't change any existing functionality (unlike the
previous version of the patchset).

Also, I am trying to use git-send-email with darcs here, so please forgive if I
have botched something in this sequence...

Yours,
   Petr.


