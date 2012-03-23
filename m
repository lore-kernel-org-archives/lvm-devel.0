From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 23 Mar 2012 15:12:16 -0400 (EDT)
Subject: [PATCH] integrate veritysetup to lvm
In-Reply-To: <4F6C58D5.7050607@redhat.com>
References: <Pine.LNX.4.64.1203212139410.18255@file.rdu.redhat.com>
	<Pine.LNX.4.64.1203212257230.29962@file.rdu.redhat.com>
	<4F6C58D5.7050607@redhat.com>
Message-ID: <Pine.LNX.4.64.1203231511120.24376@file.rdu.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Fri, 23 Mar 2012, Zdenek Kabelac wrote:

> Why not using /tools  like with do with the rest ?
> 
> Also I think some basic man page with examples of usage needs to be bundled
> with introduction of new supported tool.
> 
> Zdenek

/tools contains the lvm tool and all its commands. veritysetup is a 
separate program, it has nothing to do with lvm.

Mikulas


