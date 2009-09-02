From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 2 Sep 2009 14:26:26 +0100
Subject: [PATCH 0/9 v2]: Enforce an alphabetical lock ordering for vgname locks.
In-Reply-To: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
References: <1250198823-11591-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20090902132626.GM1655@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Aug 13, 2009 at 05:26:54PM -0400, Dave Wysochanski wrote:
> This patch series is still WIP but implements the alphabetical lock ordering.

Please add the requirement to the locking documentation in locking.h.

 * LCK_VG:
 ...
 *   If more than one lock needs to be held simultaneously, they must be 
 *   acquired in alphabetical order of 'vol' (to avoid deadlocks).

Alasdair


