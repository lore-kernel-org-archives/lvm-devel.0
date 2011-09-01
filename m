From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 1 Sep 2011 20:57:04 +0100
Subject: [PATCH] Clear up the confusing "precommit(ed)" terminology
In-Reply-To: <87d3fl4df0.fsf@aldalome.int.mornfall.net.>
References: <87d3fl4df0.fsf@aldalome.int.mornfall.net.>
Message-ID: <20110901195704.GB4025@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

phase1 -> vg_write_tentative_prepare
phase2 -> vg_write_tentative  

(format1 uses phase2 rather than phase1?)

notentative -> no_tentative or (inverted) tentative

Nope, on reflection, 'tentative' doesn't seem any better than 'precommitted'
and in some places it's worse.

More thinking needed.

Alasdair


