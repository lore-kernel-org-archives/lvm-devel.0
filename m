From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 18 Mar 2013 17:16:32 -0400 (EDT)
Subject: [PATCH] libdevmapper.h: make this include file standard-compliant
In-Reply-To: <20130316191232.GF27858@agk-dp.fab.redhat.com>
References: <Pine.LNX.4.64.1303161221480.4777@file.rdu.redhat.com>
	<20130316191232.GF27858@agk-dp.fab.redhat.com>
Message-ID: <Pine.LNX.4.64.1303181710290.7136@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Sat, 16 Mar 2013, Alasdair G Kergon wrote:

> Is there any reason for any of the code to try to support c89 these days?
> 
> I was assuming c99 as the miniumum and saw no need to support c89.
> 
> Alasdair

Include files typically need to be compatible with c89, so that users can 
compile their programs in c89 mode. (some BSD systems go even as far to 
support K&R prototypes in their include files)

In libdevmapper.h it is not critical because there are very few programs 
that use it. If you want to include c89 support, do it, but it is not 
critical.

Mikulas


