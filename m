From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 30 Apr 2010 11:55:09 +0100
Subject: [PATCH 1/3] Display errornous pattern to the user
In-Reply-To: <faa688b19e8215fa87f2e86d9362e74f15337281.1272618315.git.zkabelac@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
	<faa688b19e8215fa87f2e86d9362e74f15337281.1272618315.git.zkabelac@redhat.com>
Message-ID: <20100430105509.GC14077@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 30, 2010 at 11:07:19AM +0200, Zdenek Kabelac wrote:
> -			log_error("invalid filter pattern");
> +			log_error("Invalid filter pattern \"%s\".", v->v.str);

No need to double the quotes there?
Just %s will do.
Ack.

Alasdair


