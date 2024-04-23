Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5443D14387A
	for <lvm-devel@lists.linux.dev>; Tue, 23 Apr 2024 11:41:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1713872477; cv=none; b=KnnNy1uHRZmhqs8dBuCCPbUl0Pd90Pc0a8kAWzVWN7wyYHbK//BtmXe7XmLGGAXStX6ermUc7IwTOBexYzaeiafG8mgVG7W+D/x9iTtD/64xmqa7OPq8U0MisTRv5mAwQ7FquCJilJIuvuK4hQ+SJ5hZQ7p3oS5Or/IoUfOY6Yc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1713872477; c=relaxed/simple;
	bh=7cs8hcvGxOe8+XF0nW++PLD7YLrwh4BmmgW9cBkaWAE=;
	h=Message-ID:Date:MIME-Version:Subject:To:References:From:
	 In-Reply-To:Content-Type; b=jr7tfBABDs+WE5YjMvha1nM2JNiQCEmalnjy1tyUGg0nNuXvWq+beEDqgWO4bgn8UwT+TNAifntMgG0d3zzAgJ72o4KXMZb99mJYhMiHbJV4nCnYfpat8MdiX7waiFU/k4QFAJU8ZLWwrGEw6ZgTWCKPuDFrbzrktHzYgiQLs5U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=dwxQhQye; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dwxQhQye"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1713872475;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=fkBAabpCKXDcA/T3jNQgZ3URD34BFe9mqMN6Oz6UeRs=;
	b=dwxQhQyebM6eucn1/Gj4wfsoHWR6vU2A4yZUksJsWLifMcD5wvGSQwIuwSQJ90sXdMEMMq
	ADwEj2KszdpN+PPLII0aqO1JjoBpmhf5jsZ23yQEJALsDdG6pkbv+g997we9kfKYvIcPti
	8+Z311+YmfZubwZDr5Il8Vb4HOelC/w=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-646-fpu4h1wWMhWswtDjz2NeKQ-1; Tue, 23 Apr 2024 07:41:13 -0400
X-MC-Unique: fpu4h1wWMhWswtDjz2NeKQ-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.rdu2.redhat.com [10.11.54.8])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 7192081F450;
	Tue, 23 Apr 2024 11:41:13 +0000 (UTC)
Received: from [10.45.226.159] (unknown [10.45.226.159])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BC685C15771;
	Tue, 23 Apr 2024 11:41:12 +0000 (UTC)
Message-ID: <0df2eac5-c8ad-4e32-ac06-248b7edb8858@redhat.com>
Date: Tue, 23 Apr 2024 13:41:11 +0200
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: lvm2-monitor.servcie block boot process due to bad storage device
To: Winston Wen <wentao@uniontech.com>, lvm-devel@lists.linux.dev
References: <BA135FC1810D838F+20240423084101.40b9659c@winn-pc>
From: Zdenek Kabelac <zkabelac@redhat.com>
In-Reply-To: <BA135FC1810D838F+20240423084101.40b9659c@winn-pc>
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.8
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Language: en-US, cs
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit

Dne 23. 04. 24 v 2:41 Winston Wen napsal(a):
> Hi,
>
> If a device's IO does not respond, it will block in the path of
> partition scanning. But at this point, it has already created the
> part0, like /dev/sda, in devtmpfs, but the mutex of the device has been
> held by the partition scanning code, so all processes attempting to
> open it will enter a wait.
>
> lvm scans and opens block devices under /dev/ during startup, so if
> there are any bad devices mentioned above, lvm2-monitor.server will be
> blocked, and because its type is oneshot, it will block the boot
> process, even if the poor device is not using lvm.
>
> May I ask if there is a way to avoid it? For example, can the
> type of this service be changed from oneshot to simple? Or is there
> any other better way?


Hi

We are aware of this weakness and we are thinking about the solution for this.

However - for booting -  you should not be actually monitoring things in ramdisk

(lvm.conf should use  monitoring=0)  - so the boot is monitore-less.


Once system is switch to rootfs - monitoring should be enabled with

vgchange --monitor y  (if enabled in /etc/lvm/lvm.conf)


But we need to rethink some caching strategy - as the code for plain lvm2 
command is now causing some troubles within dmeventd instance.


Regards

Zdenek

