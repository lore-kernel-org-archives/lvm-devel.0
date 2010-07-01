From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 1 Jul 2010 15:22:20 -0500
Subject: LVM fault handling policies
Message-ID: <459C937F-B3C8-4E8D-8894-AA97F0AB8E2B@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I've put together a document that describes how LVM should behave in  
the event of a device failure (transient or permanent).  It contains  
what should be happening now, as well as some ideas for future  
improvements.  I plan on checking it in to the LVM repository after a  
bit more review.  Your thoughts are welcome.

  brassow

-------------- next part --------------
An embedded and charset-unspecified text was scrubbed...
Name: lvm_fault_handling.txt
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100701/04eb2771/attachment.txt>
-------------- next part --------------



