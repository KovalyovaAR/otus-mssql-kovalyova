CREATE PROCEDURE Sales.GetNewInvoice --будет получать сообщение на таргете
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER,
			@Message NVARCHAR(max),
			@MessageType Sysname,
			@ReplyMessage NVARCHAR(4000),
			@ReplyMessageName Sysname,
			@datefrom date,
			@dateto date,
			@cusname nvarchar(500),
			@kol int,
			@xml XML; 
	
	BEGIN TRAN; 

	--Получаем сообщение от инициатора которое находится у таргета
	RECEIVE TOP(1) 
		@TargetDlgHandle = Conversation_Handle, --ИД диалога
		@Message = Message_Body, --само сообщение
		@MessageType = Message_Type_Name --тип сообщения
	FROM dbo.TargetQueueWWI; --имя очереди которую мы ранее создавали

	SELECT @Message; --не для прода

	SET @xml = CAST(@Message AS XML);

	--достали ИД
	SELECT @datefrom = R.Iv.value('@datefrom','date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	SELECT @dateto = R.Iv.value('@dateto','date')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	SELECT @cusname = R.Iv.value('@customername','nvarchar')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	SELECT @kol = R.Iv.value('@kol','int')
	FROM @xml.nodes('/RequestMessage/Inv') as R(Iv);

	INSERT INTO Sales.OrderCount
	VALUES (@cusname, @kol, @datefrom, @dateto)
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --не для прода
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/RequestMessage' --если наш тип сообщения
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; --ответ
	    --отправляем сообщение нами придуманное, что все прошло хорошо
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle; --А вот и завершение диалога!!! - оно двухстороннее(пока-пока) ЭТО первый ПОКА
		                                   --НЕЛЬЗЯ ЗАВЕРШАТЬ ДИАЛОГ ДО ОТПРАВКИ ПЕРВОГО СООБЩЕНИЯ
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --не для прода - это для теста

	COMMIT TRAN;
END