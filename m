From: Milan Broz <mbroz@redhat.com>
Date: Tue, 15 Feb 2011 11:22:56 +0100
Subject: LVM2/lib/metadata metadata.c
In-Reply-To: <20110215020732.GE5825@agk-dp.fab.redhat.com>
References: <20110214192706.27432.qmail@sourceware.org>
	<20110215020732.GE5825@agk-dp.fab.redhat.com>
Message-ID: <4D5A5400.3080803@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 02/15/2011 03:07 AM, Alasdair G Kergon wrote:
> On Mon, Feb 14, 2011 at 07:27:06PM -0000, mornfall at sourceware.org wrote:
>> 	Fix an lv_postorder bug where it failed to clear temporary flags, making it
>> 	impossible to use twice with the same LV(s). Discovered by Milan.
> 
> Is this bug triggered by any existing code paths and if so which?

Yes, second readahead checkon the same LV == NOOP.

Milan


