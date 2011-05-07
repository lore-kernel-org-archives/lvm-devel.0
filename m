From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 7 May 2011 19:16:26 +0100
Subject: LVM2 WHATS_NEW
In-Reply-To: <20110507155250.28348.qmail@sourceware.org>
References: <20110507155250.28348.qmail@sourceware.org>
Message-ID: <20110507181626.GZ9253@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, May 07, 2011 at 03:52:50PM -0000, mornfall at sourceware.org wrote:
> +  Avoid memlock size mismatch by preallocating stdio line buffers.

If it fixed this, can't the temporary warning message suppression be
removed now?

Alasdair


