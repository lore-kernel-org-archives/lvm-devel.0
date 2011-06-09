From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 9 Jun 2011 15:23:47 +0100
Subject: [PATCH] Validate mirror segments size
In-Reply-To: <1307463386-25210-1-git-send-email-mbroz@redhat.com>
References: <1307463386-25210-1-git-send-email-mbroz@redhat.com>
Message-ID: <20110609142347.GC13427@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jun 07, 2011 at 06:16:26PM +0200, Milan Broz wrote:
> Currently some operation with striped mirrors lead
> to corrupted metadata, this patch just add detection of such
> situation.
 
Ack.

Alasdair


