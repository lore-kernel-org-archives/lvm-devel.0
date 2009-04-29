From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 29 Apr 2009 16:23:46 -0400
Subject: [PATCH 0/8]: liblvm object attribute baseline
In-Reply-To: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
References: <1241034934-25639-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1241036626.2548.6.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2009-04-29 at 15:55 -0400, Dave Wysochanski wrote:
> The following 8 patches implement a baseline for liblvm objects and their
> attributes.  The primary focus/goal of these patches are:
> 1. Define / clarify the main liblvm objects and their handles
> 2. Get the object properties for a specific handle
> 
> Together with the handles, the 'get' functions will provide equivalent
> functionality to the reporting commands (pvs, vgs, lvs) while keeping with
> the object model of liblvm.
> 
> 

I also pushed these patches on a dwysocha-liblvm-object-attr-1 branch of
the exp-git repo on git.et.redhat.com:
http://git.et.redhat.com/?p=lvm-exp.git;a=summary
http://tinyurl.com/c7m684





