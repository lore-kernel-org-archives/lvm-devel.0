From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 7 Jan 2011 13:55:43 +0000
Subject: [PATCH 2/8] Add default error path for get_property
In-Reply-To: <4D2719DC.1030008@redhat.com>
References: <cover.1294398815.git.zkabelac@redhat.com>
	<6bbe3896c9173603df3be06a3e60dd79f339e028.1294398815.git.zkabelac@redhat.com>
	<20110107134141.GC5910@agk-dp.fab.redhat.com>
	<4D2719DC.1030008@redhat.com>
Message-ID: <20110107135543.GH5910@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Jan 07, 2011 at 02:49:16PM +0100, Zdenek Kabelac wrote:
> No - all parameters passed to get_property are NULL in this case -
> so programmer's error.
 
So in what sense is it invalid?
(I'm basically asking if a more-useful error message is possible.
So you could say in it the function was called without any parameters set?)

Alasdair


