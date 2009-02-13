From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 13 Feb 2009 08:19:33 -0500
Subject: [RFC PATCH 0/12] dm_report attribute handling and liblvm vg attributes
In-Reply-To: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
References: <1234467041-21522-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1234531174.2731.129.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, 2009-02-12 at 14:30 -0500, Dave Wysochanski wrote:
> The purpose of this patchset is to get feedback on one approach to handling
> attributes in liblvm.  The most important patches are:
> 1/12: Adds dm_report_output_attribute() function and related structures.
> 9/12: Updates vg_open to store vg attributes in the handle.  This allows us
> to use the report memory safely (we free it in vg_close().
> 10/12: Add lvm_vg_get_attr_list() and lvm_vg_get_attr().
> 
> What is missing in the patch is the mode (read/write) of the attribute.
> I have not thought extensively about this but one option is as follows.
> Add a 'mode' or 'is_writable' field to the dm structure, and set it to
> 'readonly' for all attributes output by dm_report_output_attribute().
> Then in vg_open(), depending on the mode and capabilities of the current
> release of liblvm code, we can gradually change various attributes to
> writeable.
> 
> This patchset should build fine but with some warnings.  Attribute code
> was exercised with test code in last patch.
> 

These patches should apply cleanly on top of the following commit:
commit 9487820c32ded20b71422e79e74732273f1c4bef
Author: Christine Caulfield <ccaulfie@redhat.com>
Date:   Wed Feb 11 10:13:20 2009 +0000

    Add a fully-functional get_cluster_name() to clvmd corosync
interface.



> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


