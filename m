From: Marian Csontos (@csonto) <gitlab@mg.gitlab.com>
Date: Wed, 02 Aug 2023 10:22:30 +0000
Subject: [Git][lvmteam/lvm2][main] make: generate
Message-ID: <64ca2e6645108_28a6a2c7417e@gitlab-sidekiq-low-urgency-cpu-bound-v2-6fb55fb6c8-qh7fg.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Marian Csontos pushed to branch main at LVM team / lvm2


Commits:
9385bea5 by Marian Csontos at 2023-08-02T12:22:16+02:00
make: generate

- - - - -


1 changed file:

- man/lvmdevices.8_pregen


Changes:

=====================================
man/lvmdevices.8_pregen
=====================================
@@ -25,6 +25,8 @@ lvmdevices \(em Manage the devices file
  \fB-d\fP|\fB--debug\fP
 .br
     \fB--deldev\fP \fIString\fP
+.br
+    \fB--delnotfound\fP
 .br
     \fB--delpvid\fP \fIString\fP
 .br
@@ -203,6 +205,8 @@ Update the devices file to fix incorrect values.
 .br
 .RS 4
 .ad l
+[    \fB--delnotfound\fP ]
+.br
 [ COMMON_OPTIONS ]
 .ad b
 .RE
@@ -356,6 +360,11 @@ When used alone, --deldev specifies a device name.
 When used with --deviceidtype, --deldev specifies a device id.
 .
 .HP
+\fB--delnotfound\fP
+.br
+Remove devices file entries with no matching device.
+.
+.HP
 \fB--delpvid\fP \fIString\fP
 .br
 Remove a device with the PVID from the devices file.



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/9385bea57187080cbee2d19e4c7b7fe2e8af6e4a

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/commit/9385bea57187080cbee2d19e4c7b7fe2e8af6e4a
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230802/947792ef/attachment.htm>
