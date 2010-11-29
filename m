From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:16:58 +0000
Subject: [PATCH 06/29] Replace snprintf -> dm_snprintf
In-Reply-To: <ad12e2d21c4356d9d34fc8d1f752ec1d6d39dce3.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<ad12e2d21c4356d9d34fc8d1f752ec1d6d39dce3.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129201658.GW29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:10AM +0100, Zdenek Kabelac wrote:
> Use dm_snprintf with known error case behavior - return -1.
 
Ack.

Alasdair


