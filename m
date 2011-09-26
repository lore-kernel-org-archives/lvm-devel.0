From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 26 Sep 2011 16:33:44 +0200
Subject: Status 2011-09-26
Message-ID: <4E808D48.2050304@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Working on thinp internal target and got stuck with implementation of snapshot
with thinp target - as these have currently lower priority - I'm going to
continue of libdm support for thinp target
(generating target lines) and starting to think and possibly implement
activation code.


More time spend on bug fixing
 - fsadm fixes,
 - clvmd restart (didn't work at all, fixed upstream)
 - pvmove problem leaving behind devices on cluster which reveled
inconsitencies in error paths - as we may leave created devices on cluster
nodes when some node fail to suspend lv - still don't have right solution...

Zdenek


