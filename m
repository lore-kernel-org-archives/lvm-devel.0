From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 13 Apr 2010 18:45:10 +0100
Subject: [PATCH] Allow VGs with active LVs to be renamed
In-Reply-To: <4BC48819.5060203@redhat.com>
References: <4BC48819.5060203@redhat.com>
Message-ID: <20100413174510.GC25742@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 13, 2010 at 05:04:57PM +0200, Peter Rajnoha wrote:
> This patch removes the restriction for a VG rename with active LVs and it also contains
> a little cleanup for vgrename code (part of which is a fix for left-over lock when we
> failed to get the old VG).
 
Ack.

Alasdair


