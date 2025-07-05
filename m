Received: from mail-pl1-f171.google.com (mail-pl1-f171.google.com [209.85.214.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2A2672CA9
	for <lvm-devel@lists.linux.dev>; Sat,  5 Jul 2025 15:03:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1751727794; cv=none; b=X2zWNHJXH+W+XlLDZLJrdURw24+aQmiYbAJHCG4hIrcyMOSaKf5lXNzEB+B95Sx5wtKkvai81awg7dNxBT3XjM6YQs0MftEY3rWaElsDGdY7SAN2jx9Fvgj2hp106/Rnk0SsNAmn3owECpdb6E7g02Wm4VKZGUpQnKsy6b2PrBE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1751727794; c=relaxed/simple;
	bh=hxBCcGAxe0ltPiuCOzs7JcSeE+cbEWSnDfmXe34o+U0=;
	h=Message-ID:Date:MIME-Version:To:From:Subject:Content-Type; b=leuKnx+4exIc1uI4BcHkbC82+aszFaRrSHBKYbgD6+NUtsmA1eCupL51Ivz8IrhYWqoTRsDmasbgchc37LzBWqNZRxvhakJ19vSkzHlfp0Dk93hrZqOhn2II7MJnhF24+DCPHoM6YM1cw3LxlAJSOrESwsFduTGbwWl0m4G1QlY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=gLGAyHxZ; arc=none smtp.client-ip=209.85.214.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gLGAyHxZ"
Received: by mail-pl1-f171.google.com with SMTP id d9443c01a7336-236470b2dceso14431655ad.0
        for <lvm-devel@lists.linux.dev>; Sat, 05 Jul 2025 08:03:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20230601; t=1751727792; x=1752332592; darn=lists.linux.dev;
        h=content-transfer-encoding:subject:from:content-language:to
         :user-agent:mime-version:date:message-id:from:to:cc:subject:date
         :message-id:reply-to;
        bh=0PMY9sqOZtiPhYEwY4A3DGT+6wP5dLX8mImcinmE2wg=;
        b=gLGAyHxZuZ2FPtNQr4hXoTYsIcIdSxCrGzLxEWuVpVCPdzgIH0vbmCyA7NIbWimHzu
         izn+tuzBWB0EDCez3dFhz127jL1SvDtH/Yias29fe1FtifnmiTY2zOpUAOsUZIWsvR+D
         LpjPx1EOKTXL5ys2HdxgBojMaKZMRONoGviryo7EDJDAZM70LVuDhgpVP0szOpuafYbM
         ONPUCkGllqK+askFVnxgwc2XSbEGB2JFzo0Fc/kcmqbGgKA5QvvEeDrK4lrHFZ4WUDtp
         mzLJNB2T61UO20KtWZD4vsxjse00AxER+onMZ8bu/RiSp/qtKxpGtJd+hQaRpwuJRhCQ
         wt2A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20230601; t=1751727792; x=1752332592;
        h=content-transfer-encoding:subject:from:content-language:to
         :user-agent:mime-version:date:message-id:x-gm-message-state:from:to
         :cc:subject:date:message-id:reply-to;
        bh=0PMY9sqOZtiPhYEwY4A3DGT+6wP5dLX8mImcinmE2wg=;
        b=jJ32t+KBjn10x2qWcUWuuZWKCACWMNQ088qsG5Nc7YlWlFbH+kGU/BDAKhXK9Tw/py
         iAJn0tnRflJhKWYbTSb7Xtfhwpl4sNj0ZSFQWGlSb8gJf7/JsMY3tVSLfRu7iedD3OUx
         4pfbuCowBIenURnI6y84e2K4CMPscRct9M2Qt2RAdywq7TKHeJdXUNpwLgP/j5usxe3b
         mNhqJ4rLlekJncedn+JFcUjXcvYhaQPWwEe5MmdvnbDG5av1M5dQjueYgowqv9K1abNG
         3u5KJf+9S3Mn7jMeJU47WqyTayquLQknCgzOD9UY+T8lZvB3ncg+NhFJmbOBk4OE7TUp
         s1qg==
X-Gm-Message-State: AOJu0YzprcINCIzxlUqGw87NlIVmlJqSL8lHMGbcctwB3SjBZfeerptg
	HdpVEEdnfhcjKdbKVkmhOsUuPQvTedtR8WW9mwlQEDG7YpXsvWek6fsXkmpauQTG
X-Gm-Gg: ASbGnctMi4LS/SxsSasuw1XQ5oZaNpuHGwW+/LViC2mSD0Oc+INtu0Gw/E7x3kajeT7
	W3EPUKjh/7bZZgLpO48czaJrNC9fVXcWXi4Oql8MvpvvWg2HoH/6He2dxMxU9ipBff4x88Rukgw
	tcowo9oWYlPRik5vkJMnauxa4v1zyPux3ioZPAVjl4dwD7ORsptwJZLfZj6kdm4dO2SgIKRmnJ6
	VJoBzKts1S5r+SuGsEq5RSvAs1TFrENrqYKu997xPZsE/ntOAfM1lIxswGOQy0ZAHUk5NhfKsD8
	gkID/yPt6XVwJh1+wN9euKwnxQ7NWXZKNHMHhHry+AZ5RK3wR027bwxUenBclShCABS8dfC54lE
	=
X-Google-Smtp-Source: AGHT+IHGcstQqCIhreWCrYXpHkhkF5yUjqVuCKzhJOAM8XKZMO96CcxrflbJT6EJcugB4ckyKnfMHg==
X-Received: by 2002:a17:903:2343:b0:22e:4d50:4f58 with SMTP id d9443c01a7336-23c8755beebmr81538055ad.31.1751727792051;
        Sat, 05 Jul 2025 08:03:12 -0700 (PDT)
Received: from [10.0.0.64] ([124.190.141.183])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-23c8459701bsm47037285ad.205.2025.07.05.08.03.10
        for <lvm-devel@lists.linux.dev>
        (version=TLS1_3 cipher=TLS_AES_128_GCM_SHA256 bits=128/128);
        Sat, 05 Jul 2025 08:03:11 -0700 (PDT)
Message-ID: <8ab673ba-3824-4bc2-af83-9e1a04e06316@gmail.com>
Date: Sun, 6 Jul 2025 01:03:03 +1000
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
To: lvm-devel@lists.linux.dev
Content-Language: en-US
From: Andre Beaud <abacct2002@gmail.com>
Subject: a/an fixups
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Hi lvm-devel,


When looking through some output today from lvdisplay -vv, I came across 
a bit language that needed looking at - something like

"Adding some/path:6781 as an user of ..."


After some grepping this led me to some a/an fixups along with a couple 
more odds and ends. Hopefully this is useful like this as plain diff 
output, or let me know if something else will work better.


Best regards,

Andre


--- lvm2/daemons/lvmdbusd/objectmanager.py      2025-07-05 
23:34:01.908129751 +1000
+++ lvm2/daemons/lvmdbusd/objectmanager.py.new  2025-07-06 
00:14:30.153210604 +1000
@@ -272,7 +272,7 @@
                 For a given lvm asset return the dbus object path 
registered for it.
                 This method first looks up by uuid and then by lvm_id.  You
                 can search by just one by setting uuid == lvm_id (uuid 
or lvm_id).
-               If the object is not found and path_create is a not 
None, the
+               If the object is not found and path_create is not None, the
                 path_create function will be called to create a new 
object path and
                 register it with the object manager for the specified 
uuid & lvm_id.
                 Note: If path create is not None, uuid and lvm_id 
cannot be equal
@@ -295,7 +295,7 @@
                         if uuid == lvm_id:
                                 path = self._id_lookup(lvm_id)
                         else:
-                               # We have an uuid and a lvm_id we can do 
sanity checks to ensure
+                               # We have an uuid and an lvm_id, we can 
do sanity checks to ensure
                                 # that they are consistent

                                 # If a PV is missing its device path is 
'[unknown]' or some
--- lvm2/lib/metadata/lv_manip.c        2025-07-05 23:34:01.943130033 +1000
+++ lvm2/lib/metadata/lv_manip.c.new    2025-07-05 23:47:12.268598449 +1000
@@ -884,7 +884,7 @@
                 }
         }

-       log_very_verbose("Adding %s:" FMTu32 " as an user of %s.",
+       log_very_verbose("Adding %s:" FMTu32 " as a user of %s.",
                          seg->lv->name, seg->le, lv->name);

         if (!(sl = dm_pool_zalloc(lv->vg->vgmem, sizeof(*sl)))) {
--- lvm2/doc/release-notes/2.03.24.mdwn 2025-07-05 23:34:01.923129872 +1000
+++ lvm2/doc/release-notes/2.03.24.mdwn.new     2025-07-06 
00:16:27.441178429 +1000
@@ -22,7 +22,7 @@

  * **IMPORTANT:** When `devices/scan_lvs` is enabled found LVs are no 
longer auto
    activated, must enable `LVM_PVSCAN_ON_LVS` in udev rules 
(*69-dm-lvm.rules*.)
-    * NOTE: It is not recommended to use LVs for PVs. If you have an 
use case for
+    * NOTE: It is not recommended to use LVs for PVs. If you have a use 
case for
        this talk to us, please.
  * Changes to devices file are now backed up in */etc/lvm/devices/backup/*.
    Controlled by `devices/devicesfile_backup_limit` configuration option.
--- lvm2/udev/10-dm.rules.in    2025-07-05 23:34:02.040130813 +1000
+++ lvm2/udev/10-dm.rules.in.new        2025-07-06 00:17:23.977636441 +1000
@@ -86,7 +86,7 @@
  ENV{DM_UDEV_DISABLE_OTHER_RULES_FLAG}="$env{DM_COOKIE_DISABLE_OTHER_RULES_FLAG}"
  LABEL="dm_flags_done"

-# If DISK_RO is set, it's an uevent that changes the ro attribute of 
the device.
+# If DISK_RO is set, it's a uevent that changes the ro attribute of the 
device.
  # The event should be ignored as far as dm is concerned.
  ENV{DISK_RO}=="0|1", GOTO="dm_disable"

--- lvm2/lib/device/device_id.c 2025-07-05 23:34:01.933129953 +1000
+++ lvm2/lib/device/device_id.c.new     2025-07-06 00:17:50.827853950 +1000
@@ -2763,7 +2763,7 @@
   * a device, is allowed to read a device to evaluate filters that need 
to see
   * data from the dev.
   *
- * When a device id of a particular type is obtained for a dev, a id 
for that
+ * When a device id of a particular type is obtained for a dev, an id 
for that
   * type is saved in dev->ids in case it needs to be checked again.
   *
   * When a device in dev-cache is matched to an entry in the devices file
--- lvm2/lib/metadata/merge.c   2025-07-05 23:34:01.943130033 +1000
+++ lvm2/lib/metadata/merge.c.new       2025-07-06 00:18:31.846186242 +1000
@@ -523,7 +523,7 @@

                 if (seg->external_lv &&
                     !lv_is_external_origin(seg->external_lv))
-                       seg_error("external LV is not flagged as a 
external origin LV");
+                       seg_error("external LV is not flagged as an 
external origin LV");

                 if (seg->merge_lv) {
                         if (!lv_is_thin_volume(seg->merge_lv))

