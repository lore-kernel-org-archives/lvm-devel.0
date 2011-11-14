From: John Calcote <JCalcote@fusionio.com>
Date: Sun, 13 Nov 2011 22:20:25 -0700
Subject: lvm2app installation issue
Message-ID: <89CB961ABB6E1E45B7968F7C61CF3D5B61ED389C9C@MBX.int.fusionio.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I sent this request to this list last week. I wondered why no one responded to me, so I did a bit more research and discovered that the request was entirely inappropriate. It appears that it's ldconfig's job to write the soname link, not the installer's. I apologize for my ignorance.

John

From: John Calcote
Sent: Tuesday, November 08, 2011 10:27 AM
To: 'lvm-devel@redhat.com'
Subject: lvm2app installation issue

Hi all -

I'm working on an application that queries LVM2 for configuration information and displays it on the console. I wanted to use lvm2app for performance reasons, but the library is pretty new. In fact, I've found only the most recent releases of most distros even have a runtime package for this library, much less a devel package. Not wanting to give up the benefits of the library, I've decided to dynamically link to the library at runtime, and back off to parsing the output of command line utilities if the library isn't found on the system.

While testing this approach, I noticed that the liblvm makefile's install target only creates a single link (liblvm2app.so -> liblvm2app.so.2.2). Are there plans to create a liblvm2app.so.2 link so I can link to major version 2 of the library and still pick up bug fixes in minor releases?

Thanks in advance,
John

Confidentiality Notice: This e-mail message, its contents and any attachments to it are confidential to the intended recipient, and may contain information that is privileged and/or exempt from disclosure under applicable law. If you are not the intended recipient, please immediately notify the sender and destroy the original e-mail message and any attachments (and any copies that may have been made) from your system or otherwise. Any unauthorized use, copying, disclosure or distribution of this information is strictly prohibited.
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111113/fc27c5cd/attachment.htm>
