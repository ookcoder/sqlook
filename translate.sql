IF EXISTS (
	SELECT *
	FROM sys.objects
	WHERE object_id = OBJECT_ID(N'[dbo].[translate]')
			AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' )
)
DROP FUNCTION [dbo].[translate] 
GO

CREATE FUNCTION [dbo].[translate] (
	@string nvarchar(max),
	@decode bit
)
RETURNS nvarchar(max)
AS
BEGIN

	IF LEN(TRIM(@string)) = 0 RETURN ''

	DECLARE @mapping TABLE (
		alphanum char(1),
		result varchar(5)
	)

	INSERT INTO @mapping
	VALUES 
	('a', 'oO'),
	('b', 'Oooo'),
	('c', 'OoOo'),
	('d', 'Ooo'),
	('e', 'o'),
	('f', 'ooOo'),
	('g', 'OOo'),
	('h', 'oooo'),
	('i', 'oo'),
	('j', 'oOOO'),
	('k', 'OoO'),
	('l', 'oOoo'),
	('m', 'OO'),
	('n', 'Oo'),
	('o', 'OOO'),
	('p', 'oOOo'),
	('q', 'OOoO'),
	('r', 'oOo'),
	('s', 'ooo'),
	('t', 'O'),
	('u', 'ooO'),
	('v', 'oooO'),
	('w', 'oOO'),
	('x', 'OooO'),
	('y', 'OoOO'),
	('z', 'OOoo'),
	(' ', 'k '),
	('', ''),
	('0', 'OOOOO'),
	('1', 'oOOOO'),
	('2', 'ooOOO'),
	('3', 'oooOO'),
	('4', 'ooooO'),
	('5', 'ooooo'),
	('6', 'Ooooo'),
	('7', 'OOooo'),
	('8', 'OOOoo'),
	('9', 'OOOOo')

	DECLARE @result nvarchar(MAX)

	IF @decode = 0
	BEGIN
		SET @result = (
			SELECT result + CASE WHEN result = 'k ' THEN '' ELSE '0' END 
			FROM
			(
				SELECT LOWER(SUBSTRING(a.b, v.number + 1, 1)) AS 'char'
				FROM (SELECT @string b) a
				JOIN master..spt_values v ON v.number < LEN(a.b)
				WHERE v.type = 'P'
			) chars
			INNER JOIN @mapping m ON m.alphanum = chars.char
			FOR XML PATH ('')
		)

		SET @result = STUFF(@result, LEN(@result), 1, 'k')
	END
	ELSE
	BEGIN
		SET @result = (
			SELECT REPLACE((
				SELECT '' + alphanum 
				FROM (SELECT value, ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS 'rn' FROM STRING_SPLIT(SUBSTRING(@string, 1, LEN(@string) - 1), '0')) spl
				INNER JOIN @mapping m ON spl.value = m.result COLLATE Latin1_General_100_CS_AS
				ORDER BY rn
				FOR XML PATH ('')
			), '&#x20;', ' ')
		)
	END

	RETURN @result
END
GO

SELECT [dbo].[translate]('this is a test string', 0) AS 'result'
SELECT [dbo].[translate]('O0oooo0oo0ooo0k 0oo0ooo0k 0oO0k 0O0o0ooo0O0k 0ooo0O0oOo0oo0Oo0OOok', 1) AS 'result'