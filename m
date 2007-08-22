From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 22 Aug 2007 20:32:59 +0100
Subject: [LVM2 PATCH] (1/5) Fix existing mirrors calculation in lvconvert
In-Reply-To: <46CB5827.9070300@ce.jp.nec.com>
References: <46CB5827.9070300@ce.jp.nec.com>
Message-ID: <20070822193259.GH2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Aug 21, 2007 at 05:24:55PM -0400, Jun'ichi Nomura wrote:
> This patch fixes lvconvert_mirrors() to calculate the existing_mirrors
> even if the LV is striped.
 
Yep - that was wrong.

Alasdair
-- 
agk at redhat.com


