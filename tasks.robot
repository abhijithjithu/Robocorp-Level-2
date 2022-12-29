*** Settings ***
Documentation     Orders robots from RobotSpareBin Industries Inc.
...               Saves the order HTML receipt as a PDF file.
...               Saves the screenshot of the ordered robot.
...               Embeds the screenshot of the robot to the PDF receipt.
...               Creates ZIP archive of the receipts and the images.

Library        RPA.Browser.Selenium    auto_close=${False}
Library        RPA.HTTP
Library        RPA.Tables
Library        RPA.PDF
Library        RPA.Archive
Library        Dialogs
Library        RPA.Robocloud.Secrets


*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    open the robot order website
    Download csv
    ${orders}=    get Orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        fill the form    ${row}
  
    END
    


*** Keywords ***

open the robot order website
    ${website}=    Get Secret    websitedata
    Open Available Browser    ${website}[url]
    # Open Available Browser   https://robotsparebinindustries.com/#/robot-order

Download csv
    ${file_url}=     Get Value From User     Please enter the csv file url     https://robotsparebinindustries.com/orders.csv  
    Download     ${file_url}     orders.csv    overwrite=True
    # Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
get Orders
    ${tables}=    Read table from CSV    orders.csv    header=True
    RETURN    ${tables}
    # Log To Console    ${tables}
    # FOR    ${i}    IN    @{tables}
    #     Log To Console    ${i}
    # END

Close the annoying modal
    Wait And Click Button    xpath://*[@id="root"]/div/div[2]/div/div/div/div/div/button[1]
Submit the order
    TRY
        Wait And Click Button    id:order
        ${res}=    Does Page Contain Element    xpath:/html/body/div/div/div[1]/div/div[1]/div/button
        IF    ${res} == ${False}
            Submit the order        
        END        
    EXCEPT    Error message
            ${res}=    Does Page Contain Element    xpath:/html/body/div/div/div[1]/div/div[1]/div/button
        IF    ${res} == ${False}
            Submit the order        
        END
    END
         
create another robot
    Click Button     xpath:/html/body/div/div/div[1]/div/div[1]/div/button  
Preview the robot
    Wait And Click Button    id:preview
    Wait Until Element Is Visible    id:robot-preview-image
    
extract to pdf
    [Arguments]    ${row}
    ${recipt_element}=    Get Element Attribute    id:receipt    outerHTML
    Html To Pdf    ${recipt_element}    ${OUTPUT_DIR}/pdfpng${/}${row}[Order number].pdf    overwrite=True
    ${screenshot}=    Screenshot    id:robot-preview-image    ${OUTPUT_DIR}/pdfpng${/}${row}[Order number].png

    Open Pdf    ${OUTPUT_DIR}/pdfpng${/}${row}[Order number].pdf
    Add Watermark Image To Pdf    ${OUTPUT_DIR}/pdfpng${/}${row}[Order number].png    ${OUTPUT_DIR}/PDFs${/}${row}[Order number].pdf
    Archive Folder With Zip     ${OUTPUT_DIR}/PDFs    ${OUTPUT_DIR}${/}reciepts.zip

fill the form
    [Arguments]    ${row}
    Select From List By Value    id:head    ${row}[Head]
    Wait Until Element Is Visible    xpath://*[@id="root"]/div/div[1]/div/div[1]/form/div[2]/div/div[${row}[Body]]
    # Click Element    xpath://*[@id="root"]/div/div[1]/div/div[1]/form/div[2]/div/div[${row}[Body]]
    Wait And Click Button    id:id-body-${row}[Body]
    Input Text    xpath:/html/body/div/div/div[1]/div/div[1]/form/div[3]/input    ${row}[Legs]  
    Input Text    xpath://*[@id="address"]    ${row}[Address]
    Preview the robot
    Submit the order
    extract to pdf    ${row}
    create another robot
    # ${NUMTEST}=    ${row}[Order number]

 



