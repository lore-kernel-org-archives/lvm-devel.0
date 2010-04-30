From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 30 Apr 2010 11:56:36 +0100
Subject: [PATCH 2/3] Release allocated pools in error path
In-Reply-To: <a732b01db96b48347d2c9d03617df2dcef2ddd13.1272618315.git.zkabelac@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
	<a732b01db96b48347d2c9d03617df2dcef2ddd13.1272618315.git.zkabelac@redhat.com>
Message-ID: <20100430105636.GD14077@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Apr 30, 2010 at 11:07:20AM +0200, Zdenek Kabelac wrote:
> Do we want to really drop all filters here ?
 
If we can't set up all filters, it needs to be a fatal error.
(Otherwise the tools might operate on devices they shouldn't.)

Ack.

Alasdair


