Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5138714D701
	for <lvm-devel@lists.linux.dev>; Thu, 25 Apr 2024 17:02:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1714064573; cv=none; b=uCBodWcScdNjba5LP3WBiM7xGf0/j6qb2BjuccwKaZEzT8ohJIRjZbjkiAEhhvwDzEhpleBCIKFAKpdXQ04DtbC7wuwihTOLYetuvHvofSIfO9iAVlqNjOXpSj3ADwBWuqBysb8WuwunYxtn/MBxkIanHX9yE2WEu4gsxWwBcoY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1714064573; c=relaxed/simple;
	bh=zhReG2bHmoDT3VlZHwMYy0NYKCIz2qHFbpAMF9m9L4w=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 In-Reply-To:Content-Type:Content-Disposition; b=vB0Bl4FFC3Tv/qF5KEUTnbDNKD0UW4YWVPO86IYYrdnpq2NrHTCY2+wV5amkXSCdremHIDTtpCzZ065EDv8XS9cl0knflCfxWaNOmY2XnSEq1X02yW+SLnbAs1lTugALG9bXgmXASc3CKKEmtUNI1GcmvaouUjPn45A4SkDT7EE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JdSr64a3; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JdSr64a3"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1714064570;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 in-reply-to:in-reply-to:references:references;
	bh=lp1dIn3cz5tzAksZ+xEzY314VrKjys4M0mG2Uy9gVto=;
	b=JdSr64a385ACkc1Lb3mQ5z5+jyIdXDns4Mq0hYcooyFt9sgtgRw8inqG+RgO5cYxMIVwZz
	ter3eWcoZzpCLvWpIKnBE83w876JMDxpoZSZaETjw+ekjl35Us6ZrRbkSlwA8sMd8JycfE
	XFx25y0FrNZ0UtdSmrw+QO9BkG+bO9M=
Received: from mimecast-mx02.redhat.com (mimecast-mx02.redhat.com
 [66.187.233.88]) by relay.mimecast.com with ESMTP with STARTTLS
 (version=TLSv1.3, cipher=TLS_AES_256_GCM_SHA384) id
 us-mta-241-uwXZeL7eMUG8zwfTowZg9A-1; Thu, 25 Apr 2024 13:02:46 -0400
X-MC-Unique: uwXZeL7eMUG8zwfTowZg9A-1
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.rdu2.redhat.com [10.11.54.8])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mimecast-mx02.redhat.com (Postfix) with ESMTPS id 924AE80253A;
	Thu, 25 Apr 2024 17:02:46 +0000 (UTC)
Received: from redhat.com (unknown [10.22.33.135])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 5F6DBC15771;
	Thu, 25 Apr 2024 17:02:46 +0000 (UTC)
Date: Thu, 25 Apr 2024 12:02:44 -0500
From: David Teigland <teigland@redhat.com>
To: Winston Wen <wentao@uniontech.com>
Cc: lvm-devel@lists.linux.dev
Subject: Re: lvm2-monitor.servcie block boot process due to bad storage device
Message-ID: <ZiqMtOozvoNW2h-f@redhat.com>
References: <BA135FC1810D838F+20240423084101.40b9659c@winn-pc>
Precedence: bulk
X-Mailing-List: lvm-devel@lists.linux.dev
List-Id: <lvm-devel.lists.linux.dev>
List-Subscribe: <mailto:lvm-devel+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:lvm-devel+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
In-Reply-To: <BA135FC1810D838F+20240423084101.40b9659c@winn-pc>
X-Scanned-By: MIMEDefang 3.4.1 on 10.11.54.8
X-Mimecast-Spam-Score: 0
X-Mimecast-Originator: redhat.com
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Apr 23, 2024 at 08:41:01AM +0800, Winston Wen wrote:
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

I suggest using the devices file, or a filter (depending on your lvm
version) to prevent lvm from scanning devices other than PVs.

Dave

