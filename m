From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 20 May 2009 16:31:37 -0500
Subject: [PATCH] Use lvconvert --repair as a dmeventd mirror failure handler
In-Reply-To: <87r5ylbphy.fsf@mornfall.net>
References: <87r5ylbphy.fsf@mornfall.net>
Message-ID: <64033B0F-38A8-4E13-BDD6-DAFEA17C4C51@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On May 19, 2009, at 1:01 AM, Petr Rockai wrote:

> 2) If enough parallel PV space is available at the time of the  
> mirror failure,
> the failed devices will be automatically replaced using this spare  
> space. Which
> (and whether) free space may be used is still not configurable, but  
> is a
> planned feature. Since it is relatively easy to undo the action by  
> converting
> the mirror manually, I don't consider this to be a showstopper. In  
> fact, I
> think the compromise is much better than what we have now.

Wait, what?  Are you saying that with this change, it /will/ find  
space for a new mirror leg?  It doesn't do that now.  I also don't  
think lvrepair is the right place to have the allocation take place.   
'lvrepair' should do exactly that - repair.  From there, you could do  
an lvconvert.  The mirror DSO should do the 'lvconvert' portion based  
on user set policy found in /etc/lvm/lvm.conf -- see  
'mirror_log_fault_policy' and 'mirror device_fault_policy'.

Am I missing something?

  brassow


