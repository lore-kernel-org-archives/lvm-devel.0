From: Jim Meyering <jim@meyering.net>
Date: Tue, 24 Jul 2007 19:51:06 +0200
Subject: new device-mapper required to build latest lvm from cvs
Message-ID: <87wswplmgl.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

FYI, with the change I've just committed,

  http://sources.redhat.com/ml/lvm2-cvs/2007-07/msg00035.html

you now need a device-mapper library and headers built from
today's cvs sources.  Otherwise, you'll get compile warnings
and eventually a link error complaining about missing dm_fclose.


