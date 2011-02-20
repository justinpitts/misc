<?xml version="1.0"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:date="http://exslt.org/dates-and-times"
    xmlns:func="http://exslt.org/functions"
    xmlns:str="http://exslt.org/strings"
    extension-element-prefixes="date func str"
    version="1.0">
  <xsl:output omit-xml-declaration="yes" indent="no" method="text" />	
  <xsl:template match="log">
    <xsl:apply-templates select="logentry" />
  </xsl:template>
  <xsl:template match="logentry">
    <xsl:value-of select="@revision"/><xsl:value-of select="$sp"/>
    <xsl:value-of select="date" /><xsl:value-of select="$sp"/>
    <xsl:value-of select="author" /><xsl:value-of select="$sp"/>
    <xsl:apply-templates select="msg" />   
    <xsl:value-of select="$newline"/>
  </xsl:template>
  <xsl:template match="msg">
    <xsl:call-template name="break" />
  </xsl:template>
  <xsl:variable name="sp"><xsl:text> </xsl:text></xsl:variable>
  <xsl:variable name="newline"><xsl:text>&#10;</xsl:text></xsl:variable>


<xsl:template name="break">
   <xsl:param name="text" select="."/>
   <xsl:choose>
   <xsl:when test="contains($text, '&#xa;')">
      <xsl:value-of select="substring-before($text, '&#xa;')"/>
      <xsl:value-of select="$sp"/>
      <xsl:call-template name="break">
          <xsl:with-param name="text" select="substring-after($text,'&#xa;')"/>
      </xsl:call-template>
   </xsl:when>
   <xsl:otherwise>
	<xsl:value-of select="$text"/>
   </xsl:otherwise>
   </xsl:choose>
</xsl:template>
</xsl:stylesheet>