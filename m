From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 2 Dec 2015 19:18:32 +0000
Subject: [PATCH] lvmdiskscan: improve the output of this command
In-Reply-To: <1449047422-14087-1-git-send-email-lzhong@suse.com>
References: <1449047422-14087-1-git-send-email-lzhong@suse.com>
Message-ID: <20151202191832.GA11127@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Dec 02, 2015 at 05:10:22PM +0800, Lidong Zhong wrote:
>  		log_print("%d disk%s",
> -			  disks_found, disks_found == 1 ? "" : "s");
> +			  disks_found, disks_found <= 1 ? "" : "s");

"No disks" is best. "0 disks" is a lazy alternative.
"No disk" is also OK, but "0 disk" is wrong.

Alasdair


