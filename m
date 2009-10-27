From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 27 Oct 2009 16:01:18 +0000
Subject: [PATCH] Recoginse DRBD device part and handle it similar to MD devices.
In-Reply-To: <1256657513-13660-1-git-send-email-mbroz@redhat.com>
References: <1256657513-13660-1-git-send-email-mbroz@redhat.com>
Message-ID: <20091027160118.GM25303@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 27, 2009 at 04:31:53PM +0100, Milan Broz wrote:
> The DRBD uses underlying device so code should prefer top
> device if duplicate is found.
 
Ack.

Alasdair


