From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 23 Mar 2012 11:38:05 +0000
Subject: [PATCH] integrate veritysetup to lvm
In-Reply-To: <4F6C58D5.7050607@redhat.com>
References: <Pine.LNX.4.64.1203212139410.18255@file.rdu.redhat.com>
	<Pine.LNX.4.64.1203212257230.29962@file.rdu.redhat.com>
	<4F6C58D5.7050607@redhat.com>
Message-ID: <20120323113805.GA16214@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 23, 2012 at 12:04:53PM +0100, Zdenek Kabelac wrote:
> Why not using /tools  like with do with the rest ?

As we intend to package it separately, I think it makes it dependencies
more straightforward at the moment.

Alasdair


