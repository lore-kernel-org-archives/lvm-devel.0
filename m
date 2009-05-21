From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 21 May 2009 10:27:19 -0500
Subject: [PATCH] [draft] add lvconvert --repair --auto that honours lvm.conf mirror policy
In-Reply-To: <873aaybhzz.fsf@mornfall.net>
References: <873aaybhzz.fsf@mornfall.net>
Message-ID: <D9AD705C-2CD6-4EBA-A684-C167C743A0B6@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On May 21, 2009, at 10:20 AM, Petr Rockai wrote:

> I'm attaching a draft version of basic configuration capability for  
> automatic
> mirror repairs. This will make dmeventd respect the two lvm.conf  
> options
> setting failed mirror replacement policies. It doesn't affect the  
> basic
> (manual) lvconvert --repair mode (I have added --auto for that  
> purpose; it
> might need a better name though).

I like this better.  (Agree that we need different name than '--auto'.)

thanks,
  brassow


