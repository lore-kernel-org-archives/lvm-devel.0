From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:24:18 +0200
Subject: [PATCH 14/15] set clvmd build to default to cman locking backend
In-Reply-To: <20090827091638.GK643@agk-dp.fab.redhat.com>
References: <fb6b50860da53ea726698ce206000cb30a3e7381.1251363523.git.fdinitto@redhat.com>
	<b8bfce666620d1c5abea8deedd4646cd36a4bcbc.1251363523.git.fdinitto@redhat.com>
	<20090827091638.GK643@agk-dp.fab.redhat.com>
Message-ID: <1251365058.8148.269.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-08-27 at 10:16 +0100, Alasdair G Kergon wrote:
> On Thu, Aug 27, 2009 at 11:07:35AM +0200, Fabio M. Di Nitto wrote:
> > build all, as previously suggested, does not make sense.
> > Allow all to be set to avoid breaking backward compatibility,
> > but use cman instead.
>  
> How easy would it be for 'all' to build all the ones
> that can be built on a given system based on the checks
> for libs required for each?

Probably not too difficult.

I'll need to investigate it and come back to you with a patch.

Fabio


