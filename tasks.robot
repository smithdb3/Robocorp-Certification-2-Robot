*** Settings ***
Documentation       Go to website
...                 Download file and retrieve information
...                 Loop: sell my rights - Fill form - reciept HTML to PDF - screenshot robot - combine screenshot with PDF - create ZIP

Library             RPA.Browser.Selenium    auto_close=${False}
Library             RPA.HTTP
Library             RPA.PDF
Library             RPA.Desktop
Library             RPA.Tables
Library             RPA.Archive


*** Variables ***
${username}     maria
${password}     thoushallnotpass


*** Tasks ***
Order your robot
    Go to website
    Download file and retrieve information
    Create ZIP


*** Keywords ***
Go to website
    Open Available Browser    https://robotsparebinindustries.com/
    # Log in
    Input Text    xpath://input[@id="username"]    ${username}
    Input Password    xpath://input[@id="password"]    ${password}
    Click Button    xpath://button[contains(.,"Log in")]
    # Go to form
    Click Element    xpath://a[contains(.,"Order your robot!")]

Fill form and save results
    [Arguments]    ${row}    ${i}
    Wait Until Element Is Visible    xpath://button[contains(.,"OK")]    timeout=30s
    # sell my rights
    Click Button    xpath://button[contains(.,"OK")]
    Wait Until Element Is Visible    xpath://select[@id="head"]    timeout=30s
    # fill form
    ## head
    Select From List By Value    xpath://select[@id="head"]    ${row}[Head]
    ## body
    ${body_label} =    Set Variable    //label[@for="id-body-${row}[Body]"]
    Click Element    xpath:${body_label}
    # Select From List By Label    xpath://div[@class="stacked"]    ${body_label}
    ## legs
    Input Text    //input[@placeholder="Enter the part number for the legs"]    ${row}[Legs]
    ## address
    Input Text    //input[@placeholder="Shipping address"]    ${row}[Address]
    ## preview the robot
    Click Button    xpath://button[contains(.,"Preview")]
    ## submit form
    Click Button    xpath://button[@id="order"]
    Sleep    1s
    ${in_case_of_failure} =    Is Element Visible    xpath://button[@id="order"]
    WHILE    ${in_case_of_failure} == True
        Click Button    xpath://button[@id="order"]
        Sleep    1s
        ${in_case_of_failure} =    Is Element Visible    xpath://button[@id="order"]
    END
    # reciept HTML to PDF
    ${reciept_pdf} =    Set Variable    ${OUTPUT_DIR}${/}reciept_${i}.pdf
    Wait Until Element Is Visible    xpath://div[@id="receipt"]    timeout=30s
    ${reciept_html} =    Get Element Attribute    xpath://div[@id="receipt"]    outerHTML
    Html To Pdf    ${reciept_html}    ${reciept_pdf}
    # screenshot robot
    ${screenshot_png} =    Set Variable    ${OUTPUT_DIR}${/}screenshot_png_${i}.png
    Screenshot
    ...    xpath://div[@id="robot-preview-image"]
    ...    ${screenshot_png}
    # combine screenshot with PDF
    ${merged_document_pdf} =    Set Variable    ${OUTPUT_DIR}${/}merged_document_${i}.pdf
    ${files} =    Create List
    ...    ${reciept_pdf}
    ...    ${screenshot_png}
    Add Watermark Image To PDF
    ...    image_path=${screenshot_png}
    ...    source_path=${reciept_pdf}
    ...    output_path=${merged_document_pdf}
    # click order another robot
    Click Button    xpath://button[@id="order-another"]

Download file and retrieve information
    # Download
    Download
    ...    https://robotsparebinindustries.com/orders.csv
    ...    target_file=${OUTPUT_DIR}${/}
    ...    overwrite=True
    # Read the file
    ${csv_table} =    Read table from CSV    orders.csv    header=True
    ${i} =    Set Variable    ${0}
    ${x} =    Set Variable    ${0}
    FOR    ${row}    IN    @{csv_table}
        ${i} =    Set Variable    ${i+1}
        Log    i=${i}
        Fill form and save results    ${row}    ${i}
        ${x} =    Set Variable    ${x+1}
        IF    ${x} == ${3}    BREAK
    END
    # Sleep    5 minutes

Create ZIP
    Archive Folder With Zip    ${OUTPUT_DIR}${/}    Cert_2_Reciepts.zip
