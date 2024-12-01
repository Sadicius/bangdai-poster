export const fetchNui = async (eventName, data) => {
    try {
        const resp = await fetch(`https://${GetParentResourceName()}/${eventName}`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(data)
        });

        return await resp.json();
    } catch (error) {
        return null;
    }
};