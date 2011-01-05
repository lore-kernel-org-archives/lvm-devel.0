From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 5 Jan 2011 02:40:52 +0000
Subject: [PATCH 01/23] Remove dead assignment to thisfd
In-Reply-To: <a63e4321bd2f0a7919a7eaaa1696e3f1094ad1bf.1292945707.git.zkabelac@redhat.com>
References: <cover.1292945707.git.zkabelac@redhat.com>
	<a63e4321bd2f0a7919a7eaaa1696e3f1094ad1bf.1292945707.git.zkabelac@redhat.com>
Message-ID: <20110105024052.GW10297@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Dec 21, 2010 at 04:41:33PM +0100, Zdenek Kabelac wrote:
> Value 'thisfd' is not read again after this assigment.
 
Ack.

Alasdair


