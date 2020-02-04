using System;
using System.IO;
using System.Xml;
using System.Xml.Serialization;

namespace ExlCSR.BusinessLayer
{
    public static class Common
    {
        #region XmlToObject
        /// <summary>
        /// Convert xml to class object 
        /// </summary>
        /// <param name="xmlOfAnObject"></param>
        /// <param name="objectType"></param>
        /// <returns></returns>
        public static object XmlToObject(string xmlOfAnObject, Type objectType)
        {
            var strReader = new StringReader(xmlOfAnObject);
            var serializer = new XmlSerializer(objectType);
            var xmlReader = new XmlTextReader(strReader);
            object anObject = null;
            try
            {
                anObject = serializer.Deserialize(xmlReader);
            }
            catch (Exception ex)
            {
               throw new ArgumentException("Parsing Error: " + ex.Message);
            }
            finally
            {
                xmlReader.Close();
                strReader.Close();
            }
            return anObject;
        }
        #endregion

        #region GetXmlFromObject
        /// <summary>
        /// Convert class object to xml string
        /// </summary>
        /// <param name="o"></param>
        /// <returns></returns>
        public static string GetXmlFromObject(object o)
        {
            var sw = new StringWriter();
            var tw = new XmlTextWriter(sw);
            try
            {
                var serializer = new XmlSerializer(o.GetType());
                serializer.Serialize(tw, o);
            }
            catch (Exception ex)
            {
                throw new ArgumentException(ex.Message);
                //Handle Exception Code
            }
            finally
            {
                sw.Close();
                tw.Close();
            }
            return sw.ToString();
        }
        #endregion 
    }
}