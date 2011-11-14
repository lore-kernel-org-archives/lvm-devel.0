From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 14 Nov 2011 21:55:45 +0000
Subject: [PATCH 0/5] Check for resized smaller devices, v1, rhbz753914
In-Reply-To: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
References: <1321305181-28158-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20111114215545.GL4396@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

There are circumstances where sizes don't match and it's OK.
There are circumstances where sizes don't match and it's not OK.

Warn, prompt or abort?

vg_validate is really about the internal consistency of the metadata,
and I hesitate to extend it to check the underlying devices.

It's not a particularly cheap check either.
It shouldn't be done while any devices are suspended.

A flag in each PV to say to ignore a size mismatch on an individual PV,
controlled with pvchange and set when --setphysicalvolumesize overrides
it, or alternatively just a single global lvm.conf setting?

Cache the sizes during the standard scanning we already do, perhaps and
then check on (just the first?) vg read?  Re-check next time VG lock is
acquired?  (Hook into VG cache this way?)

Alasdair


