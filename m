From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 15 Feb 2011 02:07:32 +0000
Subject: LVM2/lib/metadata metadata.c
In-Reply-To: <20110214192706.27432.qmail@sourceware.org>
References: <20110214192706.27432.qmail@sourceware.org>
Message-ID: <20110215020732.GE5825@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Feb 14, 2011 at 07:27:06PM -0000, mornfall at sourceware.org wrote:
> 	Fix an lv_postorder bug where it failed to clear temporary flags, making it
> 	impossible to use twice with the same LV(s). Discovered by Milan.

Is this bug triggered by any existing code paths and if so which?
 
Alasdair


