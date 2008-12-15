From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 15 Dec 2008 22:28:02 +0000
Subject: [PATCH] Rename 'cmd' to 'clvmd_cmd' to remove ambiguity.
In-Reply-To: <1229377482-24313-1-git-send-email-dwysocha@redhat.com>
References: <1229377482-24313-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081215222802.GN19917@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Dec 15, 2008 at 04:44:42PM -0500, Dave Wysochanski wrote:
>  lib/locking/cluster_locking.c |   24 ++++++++++++------------

Ack.

Add a FIXME that some of the implicit casting needs a clean up too - signed vs unsigned?

Alasdair
-- 
agk at redhat.com


