From: Peter Rajnoha <prajnoha@redhat.com>
Date: Thu, 23 Apr 2009 14:29:29 -0400 (EDT)
Subject: [PATCH] Udev integration: udev rules - another approach
In-Reply-To: <49F0506E.8050509@redhat.com>
Message-ID: <1908437544.586521240511369345.JavaMail.root@zmail01.collab.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


If there's anybody who would like to test these rules with
updated patches applied, then you should uncomment this line
in 13-lvm.rules:

ACTION=="change", IMPORT{program}="/sbin/dmsetup lvmsplit $env{DM_NAME} --nameprefixes --noheadings --rows"

(the patch for dmsetup's "lvmsplit" command is on the list:
 [PATCH 5/5] Udev integration: add lvmsplit command for dmsetup)

...and delete this line:

ACTION=="change", TEST!="dm", IMPORT{program}="/sbin/dmsetup info $env{DM_NAME} -c --nameprefixes --noheadings --rows -o vg_name,lv_name,lv_layer"

Peter


