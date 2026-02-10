<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" standalone="no" />

<!-- **********************************************************************
 	Variables
     ********************************************************************** -->

<xsl:param name="break-at" select="'65'" />

<!-- *** error message text *** -->
<xsl:variable name="server_error_msg_text">A server error has occurred.</xsl:variable>
<xsl:variable name="server_error_des_text">Check server response code in details.</xsl:variable>
<xsl:variable name="xml_error_msg_text">Unknown XML result type.</xsl:variable>
<xsl:variable name="xml_error_des_text">View page source to see the offending XML.</xsl:variable>

<xsl:variable name="time" select="//TM" />

<!-- *** search_url *** -->
<xsl:variable name="search_url">
  <xsl:for-each select="/GSP/PARAM[(@name = 'q')]">
    <xsl:value-of select="@name"/><xsl:text>=</xsl:text>
    <xsl:value-of select="@original_value"/>
    <xsl:if test="position() != last()">
      <xsl:text disable-output-escaping="yes">&amp;</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:variable>
<!-- **********************************************************************
 Search Parameters
     ********************************************************************** -->
<!-- *** num_results: actual num_results per page *** -->
<xsl:variable name="num_results">
  <xsl:choose>
    <xsl:when test="/GSP/PARAM[(@name='num') and (@value!='')]">
      <xsl:value-of select="/GSP/PARAM[@name='num']/@value"/>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="10"/>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- *** space_normalized_query: q = /GSP/Q *** -->

<xsl:variable name="filtered">
  <xsl:choose>
    <xsl:when test="/GSP/PARAM[(@name='filter') and (@value='0')]">
      <xsl:text>&amp;filter=0</xsl:text>
    </xsl:when>
    <xsl:otherwise>
     	<xsl:text></xsl:text>
    </xsl:otherwise>
  </xsl:choose>
</xsl:variable>

<!-- *** space_normalized_query: q = /GSP/Q *** -->
<xsl:variable name="qval">
  <xsl:value-of select="/GSP/Q"/>
</xsl:variable>

<xsl:variable name="space_normalized_query">
  <xsl:value-of select="normalize-space($qval)" disable-output-escaping="yes"/>
</xsl:variable>



<!-- **********************************************************************
	 Figure out what kind of page this is 
     ********************************************************************** -->
<xsl:template match="GSP">
  <xsl:choose>
    <xsl:when test="Q">
      <xsl:call-template name="search_results"/>
    </xsl:when>
    <xsl:when test="ERROR">
      <xsl:call-template name="error_page">
        <xsl:with-param name="errorMessage" select="$server_error_msg_text"/>
        <xsl:with-param name="errorDescription" select="$server_error_des_text"/>
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:call-template name="error_page">
        <xsl:with-param name="errorMessage" select="$xml_error_msg_text"/>
        <xsl:with-param name="errorDescription" select="$xml_error_des_text"/>
      </xsl:call-template>
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

<!-- **********************************************************************
	 Search results
     ********************************************************************** -->
<xsl:template name="search_results">
	<xsl:if test="Spelling">
		<xsl:call-template name="spelling" />
	</xsl:if>
	<xsl:choose>
	<xsl:when test="RES">
	<div id="resultinfo">Results <strong><xsl:value-of select="//@SN" /> - <xsl:value-of select="//@EN" /></strong> of <xsl:value-of select="//M" /> for 
<strong><xsl:value-of select="$qval" /> </strong>
 (<strong><xsl:value-of select='format-number($time, "0.00")' /></strong> seconds)</div>

		<xsl:for-each select="//R" >
				<h3><xsl:element name="a">
				    <xsl:attribute name="href"><xsl:value-of select="U" disable-output-escaping="yes" /></xsl:attribute>
					<xsl:value-of select="T" disable-output-escaping="yes" />
					</xsl:element>
</h3>
		  <p><xsl:value-of select="S" disable-output-escaping="yes" /><br />
			  <a href="{U}" class="resultURL">
					<xsl:call-template name="break_string" >
						<xsl:with-param name="string" select="U" />
					</xsl:call-template>
				</a>
			  </p>
			<xsl:text>
			</xsl:text>
		</xsl:for-each>
		  <!-- *** Filter note (if needed) *** -->
    <xsl:if test="(RES/FI) and (not(RES/NB/NU))">
      <p>
        <em>In order to show you the most relevant results, we have omitted some entries very similar to the <xsl:value-of select="RES/@EN"/> already displayed.</em><br /><a href="?{$search_url}&amp;start={RES/@SN - 1}&amp;filter=0">Show all results</a>.
      </p>
    </xsl:if>

    <xsl:call-template name="nav_links">
      <xsl:with-param name="prev" select="/GSP/RES/NB/PU"/>
      <xsl:with-param name="next" select="RES/NB/NU"/>
      <xsl:with-param name="view_begin" select="RES/@SN"/>
      <xsl:with-param name="view_end" select="RES/@EN"/>
      <xsl:with-param name="guess" select="RES/M"/>
    </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
		<xsl:call-template name="no_RES" />
	</xsl:otherwise>
</xsl:choose>


</xsl:template>


<!-- **********************************************************************
 Navigation Links
     ********************************************************************** -->
<xsl:template name="nav_links">
    <xsl:param name="prev"/>
    <xsl:param name="next"/>
    <xsl:param name="view_begin"/>
    <xsl:param name="view_end"/>
    <xsl:param name="guess"/>
	
	<!-- Test to see whether we even need nav -->
	<xsl:if test="($prev) or ($next)"><xsl:text>
</xsl:text>
	<p class="pages">
		<xsl:choose>
			<xsl:when test="$prev" >
				<a href="?{$search_url}&amp;start={$view_begin - 11}{$filtered}">Previous</a>
			</xsl:when>
		</xsl:choose>
	
	        <xsl:variable name="mod_end">
          <xsl:choose>
            <xsl:when test="$next"><xsl:value-of select="$guess"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="$view_end"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="result_nav">
          <xsl:with-param name="start" select="0"/>
          <xsl:with-param name="end" select="$mod_end"/>
          <xsl:with-param name="current_view" select="($view_begin)-1"/>
        </xsl:call-template>

		<xsl:choose>
			<xsl:when test="$next" >
				<a href="?{$search_url}&amp;start={$view_end}{$filtered}">Next</a>
			</xsl:when>
		</xsl:choose>

	</p>
	</xsl:if>

</xsl:template>


<xsl:template name="result_nav">
  <xsl:param name="start" select="'0'"/>
  <xsl:param name="end"/>
  <xsl:param name="current_view"/>
  <xsl:param name="navigation_style"/>
  
  
  
    <!-- *** Choose how to show this result set *** -->
  <xsl:choose>
    <!--<xsl:when test="($start)&lt;(($current_view)-(10*($num_results)))">  ## Remove this so we don't get so many pages in the nav-->
	<xsl:when test="($start)&lt;(($current_view)-(($num_results)))">
    </xsl:when>
    <xsl:when test="(($current_view)&gt;=($start)) and                (($current_view)&lt;(($start)+($num_results)))">
		<span class="activepage"><xsl:value-of select="(($start)div($num_results))+1"/></span>
    </xsl:when>
    <xsl:otherwise>

        <a href="/search/?{$search_url}&amp;start={$start}{$filtered}">
        <xsl:value-of select="(($start)div($num_results))+1"/>
        </a>
    </xsl:otherwise>
  </xsl:choose>

  <!-- *** Recursively iterate through result sets to display *** -->
  <xsl:if test="((($start)+($num_results))&lt;($end)) and                 ((($start)+($num_results))&lt;(($current_view)+                 (10*($num_results))))">
    <xsl:call-template name="result_nav">
      <xsl:with-param name="start" select="$start+$num_results"/>
      <xsl:with-param name="end" select="$end"/>
      <xsl:with-param name="current_view" select="$current_view"/>
      <xsl:with-param name="navigation_style" select="$navigation_style"/>
    </xsl:call-template>
  </xsl:if>
</xsl:template>

<!-- **********************************************************************
	 Empty result set
     ********************************************************************** -->
<xsl:template name="no_RES">
  <xsl:param name="query"/>

  <p>Your search - <strong><xsl:value-of select="$qval" /></strong> - did not match any documents.</p>
  <p>No pages were found containing <strong>"<xsl:value-of select="$qval" />"</strong>.</p>
  <p>Suggestions:</p>
  <ul>
    <li>Make sure all words are spelled correctly.</li>
    <li>Try different keywords.</li>
    <li>Try more general keywords.</li>
  </ul>
  

</xsl:template>



<!-- **********************************************************************
 Display error messages
     ********************************************************************** -->
<xsl:template name="error_page">
  <xsl:param name="errorMessage"/>
  <xsl:param name="errorDescription"/>

      <p>
      <table width="99%" border="0" cellpadding="2" cellspacing="0">
        <tr>
          <td><font color="#990000" size="+1">Message:</font></td>
          <td><font color="#990000" size="+1"><xsl:value-of select="$errorMessage"/></font></td>
        </tr>
        <tr>
          <td><font color="#990000">Description:</font></td>
          <td><font color="#990000"><xsl:value-of select="$errorDescription"/></font></td>
        </tr>
        <tr>
          <td><font color="#990000">Details:</font></td>
          <td><font color="#990000"><xsl:copy-of select="/"/></font></td>
        </tr>
      </table>
      </p>
</xsl:template>

<!-- **********************************************************************
 Display Spelling Suggestion
     ********************************************************************** -->
<xsl:template name="spelling">
	<div class="suggestion">Did you mean <xsl:element name="a"><xsl:attribute name="href">/search/?q=<xsl:value-of select="/GSP/Spelling/Suggestion[1]/@q" disable-output-escaping="yes" /></xsl:attribute><xsl:value-of select="Spelling/Suggestion" disable-output-escaping="yes" /></xsl:element><xsl:text> ?</xsl:text></div>
</xsl:template>


<!-- **********************************************************************
 break_string: basically substring to $break-at
     ********************************************************************** -->
<xsl:template name="break_string">
  <xsl:param name="string" />
  <xsl:choose>
    <xsl:when test="string-length($string) &lt;= $break-at">
      <xsl:value-of select="$string" />
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="substring($string, 1, $break-at)" /><xsl:text>...</xsl:text>
      <!-- <xsl:call-template name="break_string">
        <xsl:with-param name="string"
             select="substring($string, $break-at + 1)" />
      </xsl:call-template> -->
    </xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>

